import { execSync } from "node:child_process"
import { writeFileSync, readFileSync, mkdirSync } from "node:fs"
import { join } from "node:path"

import { tool, type Plugin } from "@opencode-ai/plugin"

/**
 * BigPay adaptive-UI driver.
 *
 * Captures the app at each form factor using what's actually scriptable on
 * this machine (see `.opencode/skills/uiux/SKILL.md`). No web target — the
 * app is native-only (tflite KYC, udid, libphonenumber, pinned TLS).
 *
 * Scriptable:
 *   - Android: boot any AVD, `adb emu fold/unfold/rotate`, screencap.
 *   - iOS: boot any simulator, `simctl io booted screenshot`. Rotation and
 *     text scale have no simctl CLI — reported as guidance.
 *   - Foldable book mode is a manual emulator toolbar posture — guidance.
 */

const SHOT_DIR = join("/tmp", "bigpay-uiux")
mkdirSync(SHOT_DIR, { recursive: true })

const AVD_FOLD = "Pixel_9_Pro_Fold"
const AVD_XL = "Pixel_9_Pro_XL"
const AVD_SMALL = "Pixel_4a_API_UpsideDownCake"
const IOS_FOLDABLE_REGEXP = /Pixel_9_Pro_Fold/
const IOS_NAME_PREFIXES: Record<string, string> = {
  "candybar-small": "iPhone 16e",
  "candybar-large": "iPhone 16 Pro Max",
  "tablet-portrait": "iPad Pro 11-inch",
  "tablet-landscape": "iPad Pro 13-inch",
  "wide": "iPad Pro 13-inch",
}

/** Approximate logical widths (dp) per bucket for the report. */
const BUCKET_WIDTHS: Record<string, string> = {
  "candybar-small": "~390 (iPhone 16e) / ~393 (Pixel 4a)",
  "candybar-large": "~430 (iPhone 16 Pro Max) / ~412 (Pixel 9 Pro XL)",
  "foldable-phone": "~443 (Pixel 9 Pro Fold, folded)",
  "foldable-book": "hinge split ×2 (~426) (Pixel 9 Pro Fold, half-open)",
  "foldable-full": "~852 (Pixel 9 Pro Fold, unfolded)",
  "tablet-portrait": "~834 (iPad Pro 11) / 810 (tablet)",
  "tablet-landscape": "~1194 (iPad Pro 11) / 1366 (iPad 13)",
  "wide": "~1376 (iPad Pro 13 landscape) — the widest available target",
  "landscape-short": "height <500 (rotated phone)",
}

const BUCKETS = Object.keys(BUCKET_WIDTHS)

function run(cmd: string): string {
  return execSync(cmd, {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
    maxBuffer: 32 * 1024 * 1024,
    env: { ...process.env, PATH: `${process.env.PATH ?? ""}:/usr/local/bin:/opt/homebrew/bin` },
    shell: "/bin/zsh",
  })
    .trim()
}

function runBuf(cmd: string): Buffer {
  return execSync(cmd, {
    encoding: "buffer",
    stdio: ["ignore", "pipe", "pipe"],
    maxBuffer: 64 * 1024 * 1024,
    env: { ...process.env, PATH: `${process.env.PATH ?? ""}:/usr/local/bin:/opt/homebrew/bin` },
    shell: "/bin/zsh",
  })
}

function adbDevices(): string[] {
  try {
    const out = run("adb devices")
    return out
      .split("\n")
      .map((l) => l.trim())
      .filter((l) => /^emulator-\d+\s+device$/.test(l))
      .map((l) => l.split(/\s+/)[0])
  } catch {
    return []
  }
}

function bootAndroid(avd: string): string {
  const existing = adbDevices()
  if (existing.length > 0) {
    run(`adb -s ${existing[0]} get-state`)
    return existing[0]
  }
  execSync(`nohup emulator -avd "${avd}" -no-snapshot-load -no-boot-anim > /tmp/uiux-emulator.log 2>&1 &`, {
    env: process.env,
    shell: "/bin/zsh",
  })
  // Wait up to 120s for boot.
  const deadline = Date.now() + 120_000
  while (Date.now() < deadline) {
    try {
      const r = run("adb wait-for-device shell getprop sys.boot_completed")
      if (r === "1") {
        const devs = adbDevices()
        if (devs.length > 0) return devs[0]
      }
    } catch {
      /* not up yet */
    }
    execSync("sleep 2", { stdio: "ignore" })
  }
  throw new Error("Timed out waiting for the Android emulator to boot.")
}

function bootIos(prefix: string): string {
  const list = run("xcrun simctl list devices booted")
  const booted = list
    .split("\n")
    .filter((l) => /\(Booted\)/.test(l))
    .map((l) => l.trim().replace(/ \(Booted\)$/, ""))
    .find((l) => l.startsWith(prefix))
  if (booted) return booted
  const all = run("xcrun simctl list devices available")
  const target = all
    .split("\n")
    .map((l) => l.trim())
    .find((l) => l.startsWith(`${prefix} (`))
  if (!target) throw new Error(`No available iOS simulator matching "${prefix}".`)
  const udid = target.match(/\(([0-9A-F-]{36})\)/i)?.[1]
  if (!udid) throw new Error(`Could not parse UDID from "${target}".`)
  execSync(`xcrun simctl boot "${udid}"`, { stdio: "ignore" })
  execSync("sleep 4", { stdio: "ignore" })
  return udid
}

function androidShot(device: string, name: string): string {
  const out = runBuf(`adb -s ${device} exec-out screencap -p`)
  const sizeRaw = run(`adb -s ${device} shell wm size`)
  const path = join(SHOT_DIR, `${name}.png`)
  writeFileSync(path, out)
  return `${path}\n(wm size: ${sizeRaw})`
}

function iosShot(device: string, name: string): string {
  const path = join(SHOT_DIR, `${name}.png`)
  execSync(`xcrun simctl io ${device} screenshot "${path}"`, { stdio: "ignore" })
  return path
}

function fileAttachment(path: string) {
  return { type: "file" as const, mime: "image/png", url: `file://${path}`, filename: path.split("/").pop() }
}

function tryIosRotate(): string {
  // No simctl rotate. Best-effort AppleScript; needs Accessibility permission.
  try {
    execSync(
      `osascript -e 'tell application "Simulator" to activate' -e 'tell application "System Events" to tell process "Simulator" to click menu item "Rotate Left" of menu "Device" of menu bar 1'`,
      { stdio: "ignore", timeout: 8000 },
    )
    execSync("sleep 1", { stdio: "ignore" })
    return "Rotated via menu (if the script had permission)."
  } catch {
    return "Rotation isn't scriptable without Accessibility permission — rotate via Simulator menu Device → Rotate Left/Right, then re-run."
  }
}

const plugins: Plugin = async () => {
  async function capture(bucket: string) {
    switch (bucket) {
      case "foldable-phone": {
        const d = bootAndroid(AVD_FOLD)
        run(`adb -s ${d} emu fold`)
        execSync("sleep 3", { stdio: "ignore" })
        const r = androidShot(d, "foldable-phone")
        return { device: d, note: r, guidance: "" }
      }
      case "foldable-full": {
        const d = bootAndroid(AVD_FOLD)
        run(`adb -s ${d} emu unfold`)
        execSync("sleep 3", { stdio: "ignore" })
        const r = androidShot(d, "foldable-full")
        return { device: d, note: r, guidance: "" }
      }
      case "foldable-book": {
        const d = bootAndroid(AVD_FOLD)
        run(`adb -s ${d} emu unfold`)
        execSync("sleep 2", { stdio: "ignore" })
        const r = androidShot(d, "foldable-book")
        return {
          device: d,
          note: r,
          guidance:
            "Half-open book posture (the hinge DisplayFeature that drives isBookMode) is set from the emulator window: Extensions → fold control → drag to the middle. Then re-run this bucket.",
        }
      }
      case "candybar-small": {
        const d = bootAndroid(AVD_SMALL)
        const sizeRaw = run(`adb -s ${d} shell wm size`)
        const r = androidShot(d, "candybar-small")
        return { device: d, note: r, guidance: "" }
      }
      case "candybar-large": {
        const d = bootAndroid(AVD_XL)
        const sizeRaw = run(`adb -s ${d} shell wm size`)
        const r = androidShot(d, "candybar-large")
        return { device: d, note: r, guidance: "" }
      }
      case "landscape-short": {
        const d = bootAndroid(AVD_XL)
        run(`adb -s ${d} emu rotate 90`)
        execSync("sleep 2", { stdio: "ignore" })
        const r = androidShot(d, "landscape-short")
        return { device: d, note: r, guidance: "" }
      }
      case "tablet-portrait": {
        const device = bootIos(IOS_NAME_PREFIXES["tablet-portrait"])
        const p = iosShot(device, "tablet-portrait")
        return { device, note: p, guidance: "" }
      }
      case "tablet-landscape": {
        const device = bootIos(IOS_NAME_PREFIXES["tablet-landscape"])
        const rotate = tryIosRotate()
        const p = iosShot(device, "tablet-landscape")
        return { device, note: p, guidance: rotate }
      }
      case "wide": {
        const device = bootIos(IOS_NAME_PREFIXES.wide)
        const rotate = tryIosRotate()
        const p = iosShot(device, "wide")
        return { device, note: p, guidance: rotate }
      }
      default:
        throw new Error(`Unknown bucket "${bucket}".`)
    }
  }

  return {
    tool: {
      uiux_targets: tool({
        description:
          "List the UI/UX test targets available right now: booted iOS simulators, Android emulators on adb, and the configured foldable AVDs.",
        args: {},
        async execute(_args, _ctx) {
          const bootedIos = run("xcrun simctl list devices booted")
          const devices = adbDevices()
          const foldAvd = run("emulator -list-avds 2>/dev/null || true")
          return [
            `Booted iOS simulators:\n${bootedIos}`,
            `Android emulators (adb): ${devices.length ? devices.join(", ") : "none booted"}`,
            `Foldable AVD: ${foldAvd.includes(AVD_FOLD) ? AVD_FOLD : "NOT FOUND"}`,
            ``,
            `Available buckets: ${BUCKETS.join(", ")}`,
          ].join("\n")
        },
      }),
      uiux_screenshot: tool({
        description:
          "Capture the BigPay app at one UI/UX form factor (bucket) on a simulator/emulator and save a screenshot under /tmp/bigpay-uiux. Non-scriptable steps (iOS rotation, book posture) are reported as guidance.",
        args: {
          bucket: tool.schema.enum([...BUCKETS, "all"]),
        },
        async execute({ bucket }, _ctx) {
          if (bucket === "all") {
            const lines: string[] = []
            const attachments: string[] = []
            for (const b of BUCKETS) {
              try {
                const r = await capture(b)
                lines.push(`## ${b}\n- ${BUCKET_WIDTHS[b]}\n- ${r.device}\n- ${r.note}${r.guidance ? `\n- Note: ${r.guidance}` : ""}`)
                const last = r.note.split("\n")[0]
                if (last.endsWith(".png")) attachments.push(last)
              } catch (e) {
                lines.push(`## ${b}\n- FAILED: ${(e as Error).message}`)
              }
            }
            return {
              title: "UI/UX matrix",
              output: lines.join("\n\n"),
              attachments: attachments.map(fileAttachment),
            }
          }
          const r = await capture(bucket)
          const last = r.note.split("\n")[0]
          return {
            title: `Bucket: ${bucket}`,
            output: `Width expectation: ${BUCKET_WIDTHS[bucket]}\nDevice: ${r.device}\n${r.note}${r.guidance ? `\nGuidance: ${r.guidance}` : ""}`,
            attachments: last.endsWith(".png") ? [fileAttachment(last)] : [],
          }
        },
      }),
    },
  }
}

export default plugins satisfies Plugin