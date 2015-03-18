# Designed to be run as 
# 
# docker run -it -p 9999:8888 ipython/latest

FROM ipython/scipystack

#MAINTAINER IPython Project <ipython-dev@scipy.org>

# The ipython/ipython image has the full working copy of IPython
WORKDIR /srv/ipython/
RUN chmod a+rwX /srv/ipython/examples

# Dependencies for the example notebooks
RUN apt-get build-dep -y mpi4py
# Python dependencies
RUN pip2 install networkx vincent dill mpi4py && pip3 install vincent dill mpi4py
#RUN pip2 install scikit-image && pip3 install scikit-image 

# Install vim to make it available in the terminal
RUN apt-get install -y vim

EXPOSE 8888

# We run our docker images with a non-root user as a security precaution.
# jovyan is our user
RUN useradd -m -s /bin/bash jovyan

USER jovyan
ENV HOME /home/jovyan
ENV SHELL /bin/bash
ENV USER jovyan

RUN ipython profile create && mkdir /home/jovyan/featured

# Workaround for issue with ADD permissions
USER root
ADD common/profile_default /home/jovyan/.ipython/profile_default
RUN cp /home/jovyan/.ipython/profile_default/static/custom/* /srv/ipython/IPython/html/static/custom/ && chmod a+r /srv/ipython/IPython/html/static/custom/

# All the additions to give to the created user.
ADD notebooks/ /home/jovyan/

# ADD content here
RUN git clone --depth 1 https://github.com/jupyter/strata-sv-2015-tutorial.git /home/jovyan/strata-sv-2015-tutorial/

# Add Google Analytics templates
ADD common/ga/ /srv/ga/

RUN chown jovyan:jovyan /home/jovyan -R

## Final actions for user

USER jovyan

WORKDIR /home/jovyan/

# Example notebooks 
#RUN cp -r /srv/ipython/examples /home/jovyan/ipython_examples

RUN chown -R jovyan:jovyan /home/jovyan

# Convert notebooks to the current format
RUN find . -name '*.ipynb' -exec ipython nbconvert --to notebook {} --output {} \;
RUN find . -name '*.ipynb' -exec ipython trust {} \;

CMD ipython3 notebook
