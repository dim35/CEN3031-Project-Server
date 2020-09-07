FROM ubuntu:latest

RUN apt update -yy

RUN apt install godot3-server vim -y
RUN apt install git -y
RUN apt install python3 python3-pip -y
RUN pip3 install flask

EXPOSE 5555
EXPOSE 443

WORKDIR /server

RUN git clone https://github.com/dim35/CEN3031-Project-Server

RUN cd CEN3031-Project-Server/web && openssl req -x509 -nodes -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -subj '/CN=localhost'

CMD ["bash"]
