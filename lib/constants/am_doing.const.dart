/// What the service form flow is for — a normal transaction, or saving the
/// filled form as a beneficiary. Threaded through service → form → summary so
/// the confirmation step knows which action to run.
enum AmDoing { transaction, addBeneficiary }
