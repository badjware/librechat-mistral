#!/bin/bash -x

ollama serve &

sleep 1

for model in ${@:-mistral}; do
    ollama pull "$model"
done

wait