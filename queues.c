/* Blocking when Receiving from a Queue */
static void vSenderTask( void *pvParameters )
{
long lValueToSend;
portBASE_TYPE xStatus;


  lValueToSend = (long) pvParameters;

  for(;;)
  {
    xStatus = xQueueSendToBack( xQueue, &lValueToSend, 0);
    if( xStatus != pdPASS )
    {
      vPrintString( "Could not send to the queue.\r\n");
    }
    taskYIELD();
  }
}

static void vReceiverTask( void *pvParameters )
{
long lReceivedValue;
portBASE_TYPE xStatus;
const portTickType xTicksToWait = 100 / portTICK_RATE_MS;

  for(;;)
  {
    if( uxQueueMessagesWaiting( xQueue ) != 0)
    {
      vPrintString( "Queue should have been empty!\r\n" );
    }
    xStatus = xQueueReceive( xQueue, &lReceivedValue, xTicksToWait );
    if( xStatus == pdPASS )
    {
      vPrintString( "Received = ", lReceivedValue );
    }
    else
    {
      vPrintString( "Could not receive to the queue.\r\n");
    }
    taskYIELD();
  }
}


