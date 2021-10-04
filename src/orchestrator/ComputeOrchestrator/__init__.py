# This function is not intended to be invoked directly. Instead it will be
# triggered by an HTTP starter function.
# Before running this sample, please:
# - create a Durable activity function (default name is "Hello")
# - create a Durable HTTP starter function
# - add azure-functions-durable to requirements.txt
# - run pip install -r requirements.txt

import json

import azure.functions as func
import azure.durable_functions as df

class InputData:
    def __init__(self, input_id, instance_id, input_data):
      self.input_id = input_id
      self.instance_id = instance_id
      self.input_data = input_data

    @staticmethod
    def to_json(obj):
        return json.dumps(obj, default=lambda o: o.__dict__, sort_keys=True, indent=4)
    @staticmethod
    def from_json(stream):
        temp = json.loads(stream)
        result = InputData(temp["input_id"], temp["instance_id"], temp["input_data"])
        return result

def orchestrator_function(context: df.DurableOrchestrationContext):
    input_count = int(context.get_input())
    input_data = []
    for i in range(input_count):
        input_data.append(InputData(input_id=i, instance_id=context.instance_id, input_data=[1,1]))
    tasks = []

    for input in input_data:
        tasks.append(context.call_activity("Compute", input))
        tasks.append(context.wait_for_external_event("ComputeComplete"))

    yield context.task_all(tasks)    

main = df.Orchestrator.create(orchestrator_function)