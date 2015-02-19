# Generate SSH key pair if it does not already exist.
if [ ! -e $HOME/.ssh/id_rsa ] && [ ! -e $HOME/.ssh/id_rsa.pub ]
then
    "/usr/bin/ssh-keygen" -t rsa -N '' -f $HOME/.ssh/id_rsa
fi
