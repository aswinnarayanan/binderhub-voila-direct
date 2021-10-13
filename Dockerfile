FROM jupyter/base-notebook:python-3.7.6
# RUN pip3 install \
#     voila \
#     ipywidgets numpy matplotlib


# create a user, since we don't want to run as root
# RUN useradd -m jovyan
ENV HOME=/home/jovyan
WORKDIR $HOME

USER root
COPY simpleserver /opt/simpleserver
RUN chmod +x /opt/simpleserver

USER jovyan
COPY --chown=jovyan entrypoint.sh /home/jovyan

EXPOSE 8888

ENTRYPOINT ["/home/jovyan/entrypoint.sh"]
