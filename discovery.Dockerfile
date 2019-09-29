FROM python:3.6-alpine

RUN pip install wcraas-discovery

CMD [ "wcraas_discovery" ]
