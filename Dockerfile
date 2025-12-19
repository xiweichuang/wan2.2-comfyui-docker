FROM ghcr.io/saladtechnologies/comfyui-api:comfy0.3.76-api1.15.0-torch2.8.0-cuda12.8-runtime

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./comfyui-api"]
