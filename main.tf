########################################  Importing  modules #################################

module "computing"{
source = "./modules/computing/lambda/functions/rds/"
websg = "${module.security.websg}"
privatesubnet = "${module.networking.appsubnet}"
}

module "networking"{
source = "./modules/networking/vpc"
}

module "security"{
source = "./modules/security/sg"
myvpc = "${module.networking.myvpc}"
}
