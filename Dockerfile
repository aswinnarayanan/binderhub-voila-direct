FROM jupyter/base-notebook:python-3.7.6
# RUN pip3 install \
#     voila \
#     ipywidgets numpy matplotlib


# create a user, since we don't want to run as root
# RUN useradd -m jovyan
ENV HOME=/home/jovyan
WORKDIR $HOME

USER root
COPY simpleserver8080 /opt/simpleserver8080
RUN chmod +x /opt/simpleserver8080
COPY simpleserver8888 /opt/simpleserver8888
RUN chmod +x /opt/simpleserver8888

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

USER jovyan
EXPOSE 8080
EXPOSE 8888

ENTRYPOINT ["/opt/entrypoint.sh"]
