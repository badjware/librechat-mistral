# librechat-mistral

A quick prototype to self-host [LibreChat](https://github.com/danny-avila/LibreChat) with [Mistral](https://mistral.ai/news/announcing-mistral-7b/), and a OpenAI-like api provided by [LiteLLM](https://github.com/BerriAI/litellm) on the side.

**Currently setup to run on an AMD GPU (RX 7xxx series), although the deployment could be adapted for Nvidia or other AMD GPUS**

## Goals

* Deploy a ChatGPT Clone for daily use.
* Deploy an OpenAI-like API for hacking on Generative AI using well-supported libraries.
* Use docker to prepare for an eventual deployment on a container orchestration platform like Kubernetes.

## Getting started

### Prerequisites

* Linux (WSL2 is untested)
* An AMD 7xxx series GPU (technically optional, Ollama will fallback to using the CPU but it will be very slow. Other GPUS are supported but the deployment must be modified to use them)
* docker
* docker-compose

### Steps

1. Clone the repo
2. Run `docker-compose up`. Wait for a few minutes for the model to be downloaded and served.
3. Browse http://localhost:3080/
4. Create an admin account and start chatting!

The API along with the APIDoc will be available at http://localhost:8000/

## Configuring additional models

### SASS services

Read: https://docs.librechat.ai/install/configuration/dotenv.html#endpoints

**TL:DR**

Let say we want to configure an OpenAI API key.

1. Open the *.env* file.
2. Uncomment the line `# OPENAI_API_KEY=user_provided`.
3. Replace `user_provided` with your API key.
4. Restart LibreChat `docker-compose restart librechat`.

Refer to the LibreChat documentation for the full list of configuration options.

### Ollama (self-hosted)

Browse the [Ollama models library](https://ollama.ai/library) to find a model you wish to add. For this example we will add [mistral-openorca](https://ollama.ai/library/mistral-openorca)

1. Open the *docker-compose.yml* file.
2. Find the `ollama` service. Find the `command:` option under the ollama sevice. Append the name of the model you wish to add at the end of the list (eg: `command: mistral mistral-openorca`).
3. Open the *litellm/config.yaml* file.
4. Add the following a the end of the file, replace {model_name} placeholders with the name of your model
``` yaml
  - model_name: {model_name}
    litellm_params:
      model: ollama/{model_name}
      api_base: http://ollama:11434
```
eg:
``` yaml
  - model_name: mistral-openorca
    litellm_params:
      model: ollama/mistral-openorca
      api_base: http://ollama:11434
```
5. Open the *librechat/librechat.yaml* file.
6. In our case, **mistral-openorca** is a variation of **mistral-7b** so we will group it with the existing **Mistral** endpoint. Refer to the [LibreChat documentation](https://docs.librechat.ai/install/configuration/custom_config.html#custom-endpoint-object-structure) if you wish to organize your new model as a new Endpoint.
``` yaml
      models: 
        default: ["mistral-7b"]
```
becomes:
``` yaml
      models: 
        default: ["mistral-7b", "mistral-openorca"]
```
7. Restart the stack `docker-compose restart`. Wait for a few minutes for the model to be downloaded and served.

## Architecture components

* [LibreChat](https://github.com/danny-avila/LibreChat) is a ChatGPT clone with support for multiple AI endpoints. It's deployed alongside a [MongoDB](https://github.com/mongodb/mongo) database and [Meillisearch](https://github.com/meilisearch/meilisearch) for search. It's exposed on http://localhost:3080/.
* [LiteLLM](https://github.com/BerriAI/litellm) is an OpenAI-like API. It is exposed on http://localhost:8000/ without any authentication by default.
* [Ollama](https://github.com/ollama/ollama) manages and serve the local models.

## TODO

At the time of this project, I only had access to a Linux machine with an AMD RX 7800XT GPU. I would like to include support for Windows and/or Nvidia GPUs when I get the chance.