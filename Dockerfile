FROM nginx:alpine
RUN mkdir -p /usr/share/nginx/html/data-export/code
COPY index.html /usr/share/nginx/html/data-export
COPY code/dataExport.sas /usr/share/nginx/html/data-export/code/