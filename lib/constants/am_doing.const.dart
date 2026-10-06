/// What the service form flow is for — a normal transaction, saving the
/// filled form as a beneficiary, or correcting a saved beneficiary's details
/// and then paying them ("edit and send"). Threaded through service → form →
/// summary so the confirmation step knows which action(s) to run.
enum AmDoing { transaction, addBeneficiary, editBeneficiary }
