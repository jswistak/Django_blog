# Django_blog

Django blog is simple blog made with Django `3.0.3`

## Getting Started

Setup project environment with [virtualenv](https://virtualenv.pypa.io) and [pip](https://pip.pypa.io).

```bash
# Download
$ git clone https://github.com/jakub0301/Django_blog
$ cd Django_blog

# Create virtual environment
$ virtualenv venv
$ source venv/bin/activate

# Install requirements
$ pip install -r requirements.txt

$ cd django_blog/
$ python manage.py runserver
```

## Deployment

### Infrastructure

The project infrastructure is defined using Terraform on Google Cloud Platform (GCP).

### Deployment to Artifact Registry

Set environment variables for the project and region:

```bash
export PROJECT_ID=helical-gist-453315-a2
export REGION=europe-west1
```

Authenticate with GCP:

```bash
gcloud auth configure-docker ${REGION}-docker.pkg.dev
```

Build and push Docker image:

```bash
# For macOS M1 users, specify platform
docker buildx build --platform=linux/amd64 -t my-django-app .

# Tag the image
docker tag my-django-app ${REGION}-docker.pkg.dev/${PROJECT_ID}/containers-django/djangoapp:latest

# Push to Artifact Registry
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/containers-django/djangoapp:latest
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Home Page Screen

<img width="1920" alt="Homepage" src="https://user-images.githubusercontent.com/16799850/76349775-e883dc80-630a-11ea-823d-5922104b3612.png">
