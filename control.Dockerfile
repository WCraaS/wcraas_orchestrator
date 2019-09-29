FROM python:3.6-alpine as base

# aioredis uses hiredis C bindings for performance optimization
# and since alpine doesn't fall under manylinux classification
# there are no pre-built wheels for aioredis we can use here.
# For this reason, we do a multistage docker image build, with the
# first stage, the builder, loading the build dependencies and
# installing aioredis (which is subsequently built at that point)
# and the second stage, the actual image, forking over the install
# directory. This allows us to have aioredis "pre-installed" in the
# final image, whithout burdening it with hiredis' build dependencies.

FROM base as builder

RUN apk add gcc python3-dev musl-dev

RUN mkdir /install
WORKDIR /install

RUN pip install aioredis --root /install/ --prefer-binary --no-warn-script-location

FROM base

COPY --from=builder /install /install

RUN cp -r /install/usr/local/lib/python3.6/site-packages/* usr/local/lib/python3.6/site-packages/ && \
    pip install wcraas-control && \
    rm -rf /install && \
    rm -rf /tmp/pip* && \
    rm -rf /root/.cache/pip/ && \
    rm -rf /var/cache

# The command bellow keeps the container running without executing the control worker.
# This will eventually be replaced when the control worker is attached to an own REST
# API server.
CMD [ "tail", "-f", "/dev/null" ]
