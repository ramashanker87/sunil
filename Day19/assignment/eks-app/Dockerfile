FROM python:3.12-slim
 
WORKDIR /ecs-app
 
COPY app_eks.py .

ENV PARTICIPANT_NAME=sunil
 
CMD ["python", "app_eks.py"]
