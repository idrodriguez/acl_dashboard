FROM ubuntu:18.10

LABEL maintainer="Ivan Rodriguez <irodriguez.salguero@gmail.com>"

RUN apt-get update

# Setup Timezone to Madrid
RUN apt-get install -y apt-utils locales tzdata

RUN echo "Europe/Madrid" | tee /etc/timezone && \
    ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Install ODBC Driver 17 for SQL Server

RUN apt-get install -y curl gnupg
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql17

# Install Python3 and ODBC headers
RUN apt-get install -y python3 python3-dev python3-pip unixodbc-dev 

# We copy just the requirements.txt first to leverage Docker cache
COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

# Install python packages from a requirement list
RUN pip3 install -r requirements.txt

COPY . /app

ENTRYPOINT [ "python3" ]

CMD [ "acl_dashboard/app.py"]