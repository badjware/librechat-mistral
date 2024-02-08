#!/bin/bash -x

# Ollama has trouble handling HTTP_PROXY
# https://github.com/ollama/ollama/issues/2168
unset HTTP_PROXY
unset http_proxy

ollama serve &

sleep 1

for model in ${@:-mistral}; do
    ollama pull "$model"
done

wait