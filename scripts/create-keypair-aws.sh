#!/bin/bash
PUBLIC_KEY_PATH="$HOME/.ssh/id_rsa.pub"
PUBLIC_KEY_NAME="my-key"

if [[ -z "$2" ]]; then
	echo "Define custom Public Key Path [$PUBLIC_KEY_PATH]: "
	read TMP_KEY
	if ! [[ -z $TMP_KEY  ]]; then
		PUBLIC_KEY_PATH=$TMP_KEY
	fi
else
	PUBLIC_KEY_PATH="$2"
fi

echo "Selected public key path: $PUBLIC_KEY_PATH"

if [[ -z "$1" ]]; then
echo "Define custom Public Key Name [$PUBLIC_KEY_NAME]: "
read TMP_KEY
if ! [[ -z $TMP_KEY  ]]; then
	PUBLIC_KEY_NAME=$TMP_KEY
fi
else
	PUBLIC_KEY_NAME="$1"
fi

echo "Selected public key name: $PUBLIC_KEY_NAME"

echo -e "\n"

if [[ -e $PUBLIC_KEY_PATH ]]; then
	PUBLIC_KEY_BLOB="$(cat $PUBLIC_KEY_PATH|grep -v '\-\-')"
	echo "Public Key Value: $PUBLIC_KEY_BLOB"
	echo -e "\n"
	echo -e "Cleaning existing keys..."
	aws ec2 delete-key-pair --key-name "$PUBLIC_KEY_NAME"
	echo -en "\e[1A"; echo -e "\e[0K\rCleaning existing keys...done!!"
	sleep 2
	echo "Creating new key pair in AWS..."
	aws ec2 import-key-pair --key-name "$PUBLIC_KEY_NAME" --public-key-material "$PUBLIC_KEY_BLOB"
	if [[ "$?" == "0" ]]; then
		echo "done!!"
		exit 0
	else
		echo "failed!!"
		exit 1
	fi
else
	echo "Public Key: $PUBLIC_KEY_PATH doesn't exist!!"
	exit 1
fi
