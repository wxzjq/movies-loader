FROM python:2.7.10
LABEL MAINTAINER mlabouardy

WORKDIR /app 

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY movies.json main.py ./

CMD python main.py