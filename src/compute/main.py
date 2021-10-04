import os, logging, json, time
from azure.storage.queue import (
    QueueClient
)
from azure.storage.blob import (
    BlobServiceClient,
)
import algorithm

logging.basicConfig(level=os.environ.get("LOGLEVEL", "INFO"))

def build_output_data(job_configuration, blob_service_client, output_blob_container_name, result):
    path_to_output_file = f"{job_configuration['path_to_data']}"

    output_blob_client = blob_service_client.get_blob_client(container=output_blob_container_name, blob=path_to_output_file)

    output = {
      "input_id": job_configuration['input_id'],
      "instance_id": job_configuration['instance_id'],
      "result": result
    }

    output_json = json.dumps(output, indent=4)
    return path_to_output_file, output_blob_client, output_json

def build_input_data(job_configuration, blob_service_client, input_blob_container_name, log):
    path_to_input_file = f"{job_configuration['path_to_data']}"

    input_blob_client = blob_service_client.get_blob_client(container=input_blob_container_name, blob=path_to_input_file)

    log.info(f"Downloading input blob: {path_to_input_file}")

    input_file_stream = input_blob_client.download_blob().readall()

    input_json = json.loads(input_file_stream)
    return input_json, path_to_input_file, input_blob_client

def main():
    log = logging.getLogger(__name__)

    connection_string = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
    queue_name = os.getenv("AZURE_STORAGE_QUEUE_NAME")
    input_blob_container_name = os.getenv("AZURE_STORAGE_INPUT_BLOB_CONTAINER_NAME")
    output_blob_container_name = os.getenv("AZURE_STORAGE_OUTPUT_BLOB_CONTAINER_NAME")
    sleep_time_in_seconds = os.getenv("LOOP_SLEEP_TIME_IN_SECONDS")

    blob_service_client = BlobServiceClient.from_connection_string(connection_string)

    queue_client = QueueClient.from_connection_string(connection_string, queue_name)

    loop_count = 0

    while(True):
        messages = queue_client.receive_messages()

        log.info("Processing all messages")

        for message in messages:
            log.info(f"Processing message: {message.id}")

            job_configuration = json.loads(message.content)

            input_json, path_to_input_file, input_blob_client = build_input_data(job_configuration, blob_service_client, input_blob_container_name, log)

            # -- your algorithm goes here --
            result = algorithm.compute(log, input_json['input_data'])

            path_to_output_file, output_blob_client, output_json = build_output_data(job_configuration, blob_service_client, output_blob_container_name, result)
            
            log.info(f"Uploading output blob: {path_to_output_file}")

            output_blob_client.upload_blob(output_json)

            log.info(f"Removing message {message.id} from queue")

            queue_client.delete_message(message.id, message.pop_receipt)

            log.info(f"Deleting input blob file: {path_to_input_file}")

            input_blob_client.delete_blob()

            loop_count = 0

        loop_count = loop_count + 1

        log.info(f"Sleeping for {sleep_time_in_seconds}...")

        time.sleep(sleep_time_in_seconds)

if __name__=="__main__":
    main()