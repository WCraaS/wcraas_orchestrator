# wcraas_orchestrator

Orchestration examples for the WCraaS platform in docker-compose

A working example that brings the main components of the `WCraaS` platform together.

## Configuring

Some elements of the orchestration can be configured through environment variables.

There are a few configuration points currently (more will follow for added flexibility):

* ENV_COTTONTAIL_MGMT_IFACE
    * The interface on which to expose the rabbitmq management dashboard
    * Leave empty for unmapped
    * if provided must end with `:`!
* ENV_COTTONTAIL_USER
    * Username for the default rabbitmq user
* ENV_COTTONTAIL_PASS
    * Password for the default rabbitmq user
* ENV_QUEUE_COLLECTION_MAP
    * A `JSON` object with string keys and string values
    * Used by the wcraas_storage node(s) to determine the target MongoDB collection for an operation based on the source rabbitmq topic

### Example configuration

Create a `.env` file (all `/*.env` files are ignored in this repository) and declare the above values:


```sh
echo 'ENV_COTTONTAIL_MGMT_IFACE=127.0.0.1:' >> .env
echo 'ENV_COTTONTAIL_USER=guest' >> .env
echo 'ENV_COTTONTAIL_PASS=guest' >> .env
echo 'ENV_QUEUE_COLLECTION_MAP={"discovery_raw": "raw", "discovery_graph": "graph"}' >> .env
```

The above configuration will inform `docker-compose` to:

* Expose the rabbitmq management dashboard on localhost (`127.0.0.1`); Note the trailing `:`!
* Set the rabbitmq default user's username to guest
* Set the rabbitmq default user's password to guest
* Subscribe the storage worker to the `discovery_raw` and `discovery_graph` topics and insert incoming messages to `raw` and `graph` collections accordingly

## Bring the stack up

Unfortunately since `docker-compose` has no built-in way to load an environment file we have to do it pre-pend the following on each `docker-compose up` command:


```sh
env $(cat .env)
```

So, in order to bring the whole stack up one would do:


```sh
env $(cat .env) docker-compose up -d
```

The suggested approach here however would be to first bring the underlying dependecies up and then the WCraaS layer:

```sh
env $(cat .env) docker-compose up -d mongo redis cottontail
# Wait a few seconds (30 ?) for rabbitmq to start accepting connections
env $(cat .env) docker-compose up -d
```

Finally, enter the control node and execute the `wcraas_control` command:


```sh
docker exec -it wcraas_control sh
wcraas_control <ENTRYPOINT_URL>
```

The above step will be obsoleted in the future, as the paln is to provide WCraaS control node with an own REST API.
