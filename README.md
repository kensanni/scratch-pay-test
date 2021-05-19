# scratch-pay-test
Solution for Scratchpay technical test

## **Prerequisites**
To run this solution on your local machine, ensure you have the following installed

1. [Terraform](https://www.terraform.io/) version 0.15 or greater on your machine.
2. [Docker](https://www.docker.com/products/docker-desktop) and [Docker-compose](https://docs.docker.com/compose/install/)
3. [Helm v3](https://helm.sh/docs/intro/install/)

## Running the API
The Rest API is built with [postgresql](https://www.postgresql.org/), [express.js](https://expressjs.com/) and [Nodejs](https://nodejs.org/en/). For easy step and to account for different OS that might be used to run the app, the api has been dockerized and set up with `docker-compose`. Follow the steps below to get the app running:

1. Clone this repository into your local machine
    ```
    git clone https://github.com/kensanni/scratch-pay-test.git
    ```

2.  Move into the `scratchpay-api` directory
    ```
      cd scratchpay-api
    ```

3.  Create a new file `.env`, copy the content of `.env.sample` to the `.env` file 
    ```
    cp .env.example .env
    ```

    Replace the undefined environment variables with any value of your choice in the `.env` file.

4.  Run `docker-compose up --build` to start the application. Your application will be accessible on port `7000`

5. To stop and destroy the container running the app, simply run `docker-compose down` command

## Creating the Google Kubernetes Engine(GKE) with terraform.

To spin up the kubernetes cluster on google cloud with terraform, follow the steps below

1. move into the `terraform-gke` directory
   ```
    cd terraform-gke
   ```

2. Ensure you have your [google service account](https://cloud.google.com/iam/docs/service-accounts) key setup and downloaded.

3. Initialize terraform by running the `terraform init` command.

    ```command
      terraform init
    ```
4. Export both your project id and google service account key path.

    ```command
    export GOOGLE_PROJECT_ID="YOUR_GOOGLE_PROJECT_ID"
    export GOOGLE_CREDENTIALS="YOUR_GOOGLE_SERVICE_ACCOUNT_KEY_PATH"
    ```
  
   Create a `terraform.tfvars` file containing the exported values.
  
    ```command
    cat > terraform.tfvars <<EOF               
    project="$GOOGLE_PROJECT_ID"
    credentials="$GOOGLE_CREDENTIALS"
    EOF
    ```

5. Apply terraform changes by running `terraform apply` command

    ```command
      terraform apply
    ```
  
  This will create a kubernetes clustur on Google Kubernetes Engine.


## Deploying the application to GKE with helm

The application is deployed to the kubernetes cluster using helm and kubectl. Follow the guide below to deploy the manifests to GKE

1. Move into the `kubernetes-manifest` directory
   ```
    cd kubernetes-manifest
   ```
2. Generate the manifest files by running the command below
   ```
   helm template -f kubernetes/helm-profiles/default.yaml --output-dir=manifests kubernetes/helm
   ```
3. Apply the manifest file by running the command below
   ```
   kubectl apply -Rf manifests/scratch-pay/templates
   ```