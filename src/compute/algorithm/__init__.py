import time

def compute(log, inputData):
    log.info("Computing result...")
    
    time.sleep(5)
    
    result = sum(inputData)

    log.info("Result: " + str(result))

    return result