variable "source_account_ids" {
  description = "List of all source AWS account IDs that will send metrics to AMP"
  type        = list(string)
  default = [
    # Production Accounts
    "840066156479", # core-prod
    "814167067247", # core-prod-security
    "194374732776", # core-prod-storage
    "986788162487", # core-prod-workload
    "376129876930", # counselling-prod
    "484021612095", # ethinos-prod
    "503561424407", # PaymentPro-Prod
    "573811483933", # Grooming-School-Lms-Prod
    "039138653430", # TOMMS
    # Non-Production Accounts
    "596338505229", # core-nonprod-audit
    "579286803788", # core-nonprod-networking
    "081027471069", # core-nonprod-security
    "509235756237", # core-nonprod-storage
    "228227093546", # core-nonprod-workload
    "992382651259", # counselling-nonprod
    "337909775485", # PaymentPro-NonProd
    "243244970719", # NonProd
    "025688828853", # Grooming-School-LMS-Moodle
    # Core/Governance
    "441508417985", # Core_Account_Network
    "560885581232", # Core_Complience
    "968311652915", # Core_Governance
    # Sandbox/Dev
    "248189944202", # AI_Hackathon
    "196252597537", # devika-sandbox
    "713678752742", # devops-team
    "343268907886", # finbot
    "316929918327", # swap-devops
    # Other
    "903001346340", # BOT_Process
    "652892608280", # TEELSSA
    "226563001214", # TimesGroup-TEEL
    "734352162710", # executive-education
    "884614646509", # ethinos
  ]
}
