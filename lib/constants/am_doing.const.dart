/// What the service form flow is for — a normal transaction, or saving the
/// filled form as a beneficiary. Threaded through service → form → summary so
/// the confirmation step knows which action to run.
///
/// "Edit & send" is just a transaction with a pre-filled form, so it uses
/// [AmDoing.transaction].
enum AmDoing { transaction, addBeneficiary }
