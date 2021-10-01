# This function is not intended to be invoked directly. Instead it will be
# triggered by an orchestrator function.
# Before running this sample, please:
# - create a Durable orchestration function
# - create a Durable HTTP starter function
# - add azure-functions-durable to requirements.txt
# - run pip install -r requirements.txt

import os, json
from azure.storage.blob import (
    BlobServiceClient
)
from azure.storage.queue import (
    QueueClient
)

def main(input) -> str:
    connection_string = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
    queue_name = os.getenv("AZURE_STORAGE_QUEUE_NAME")
    input_blob_container_name = os.getenv("AZURE_STORAGE_INPUT_BLOB_CONTAINER_NAME")

    queue_client = QueueClient.from_connection_string(connection_string, queue_name)

    blob_service_client = BlobServiceClient.from_connection_string(connection_string)

    path_to_output_file = f"{input.instance_id}/{input.input_id}.json"

    output_blob_client = blob_service_client.get_blob_client(container=input_blob_container_name, blob=path_to_output_file)

    output_json = json.dumps(input, default=lambda o: o.__dict__, sort_keys=True, indent=4)

    output_blob_client.upload_blob(output_json)

    queue_message = {
      "input_id": input.input_id,
      "instance_id": input.instance_id,
      "path_to_data": path_to_output_file
    }

    queue_client.send_message(json.dumps(queue_message, indent=4))

    return "Complete"