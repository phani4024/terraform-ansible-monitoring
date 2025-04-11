resource "aws_instance" "terraform" {
  tags = {
    Name = var.iname
  }
  ami                    = var.ami_id
  instance_type          = var.itype
  key_name               = var.kname
  vpc_security_group_ids = [var.sg_id]
  root_block_device {
    volume_size = 15
  }
}
