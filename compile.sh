#! /bin/sh

cargo build --release
terraform apply -auto-approve
