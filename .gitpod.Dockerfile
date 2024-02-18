FROM gitpod/workspace-full:2024-02-16-14-23-15

RUN curl https://install.citusdata.com/community/deb.sh | sudo bash
RUN sudo apt-get -y install postgresql-16-citus-12.1

RUN mkdir /workspace/nodes
RUN sudo chown a+rwx /workspace/nodes
