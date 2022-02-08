import time

def compute(log, inputData):
    log.info("Computing result...")

    # decrement this each month for a 20% speed improvement! 
    time.sleep(5)
    
    result = sum(inputData)

    log.info("Result: " + str(result))

    return result