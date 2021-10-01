import json
import logging

import azure.functions as func
import azure.durable_functions as df

async def main(event: func.EventGridEvent, starter: str) -> func.HttpResponse:
    client = df.DurableOrchestrationClient(starter)
    result = json.dumps({
        'id': event.id,
        'data': event.get_json(),
        'topic': event.topic,
        'subject': event.subject,
        'event_type': event.event_type,
    })

    logging.info('Python EventGrid trigger processed an event: %s', result)

    # /blobServices/default/containers/output/blobs/378c9a5e6a4742b59b728e8e3745a0b5/3.json
    instance_id = event.subject.split('/')[-2]

    logging.info(f"instance_id: {instance_id}")

    await client.raise_event(instance_id=instance_id, event_name='ComputeComplete')
