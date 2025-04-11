module "my_instance_module" {
  source = "./modules/instance/"
  iname  = var.iname
  ami_id = var.ami_id
  itype  = var.itype
  kname  = var.kname
  sg_id  = var.sg_id
}
