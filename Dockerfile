FROM ubuntu:18.10

LABEL maintainer="Ivan Rodriguez <irodriguez.salguero@gmail.com>"

RUN apt-get update

RUN apt-get install -y \
    apt-utils \
    locales \
    tzdata

RUN echo "Europe/Madrid" | tee /etc/timezone && \
    ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

RUN apt-get install -y python3 python3-dev python3-pip unixodbc-dev 

# We copy just the requirements.txt first to leverage Docker cache
COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip3 install -r requirements.txt

COPY . /app

ENTRYPOINT [ "python3" ]

CMD [ "acl_dashboard/app.py"]