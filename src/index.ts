import { ponder } from '@/generated'

ponder.on('BaluniV1Router:Mint', async ({ event, context }) => {
  const { MintEvent } = context.db

  console.log('Processing Mint event:', event.args)

  // Additional debug logs
  console.log('Mint event log ID:', event.log.id)
  console.log('Mint event user:', event.args.user)
  console.log('Mint event value:', event.args.value.toString())

  try {
    await MintEvent.create({
      id: event.log.id,
      data: {
        user: event.args.user,
        value: event.args.value,
      },
    })
    console.log('MintEvent created successfully')
  } catch (error) {
    console.error('Error creating MintEvent:', error)
    console.error('Store method arguments:', {
      id: event.log.id,
      user: event.args.user,
      value: event.args.value.toString(),
    })
  }
})

// Similarly, update other event handlers if necessary
ponder.on('BaluniV1Router:Execute', async ({ event, context }) => {
  const { ExecuteEvent, Call } = context.db

  console.log('Processing Execute event:', event.args)

  const callData = event.args.calls.map((call: any, index: number) => ({
    id: `${event.log.id}-call-${index}`,
    to: call.to,
    value: call.value.toString(),
    data: call.data,
  }))

  await Promise.all(
    callData.map(async (call) => {
      await Call.create(call)
    })
  )

  await ExecuteEvent.create({
    id: event.log.id,
    data: {
      user: event.args.user,
      calls: callData.map((call) => call.id),
      tokensReturn: event.args.tokensReturn,
    },
  }).catch((error) => {
    console.error('Error creating ExecuteEvent:', error)
    console.error('Store method arguments:', {
      id: event.log.id,
      user: event.args.user,
      calls: callData.map((call) => call.id),
      tokensReturn: event.args.tokensReturn,
    })
  })
})

ponder.on('BaluniV1Router:Burn', async ({ event, context }) => {
  const { BurnEvent } = context.db

  console.log('Processing Burn event:', event.args)

  await BurnEvent.create({
    id: event.log.id,
    user: event.args.user,
    value: event.args.value.toString(),
  }).catch((error) => {
    console.error('Error creating BurnEvent:', error)
    console.error('Store method arguments:', {
      id: event.log.id,
      user: event.args.user,
      value: event.args.value.toString(),
    })
  })
})

ponder.on('BaluniV1Router:Log', async ({ event, context }) => {
  const { LogEvent } = context.db

  console.log('Processing Log event:', event.args)

  await LogEvent.create({
    id: event.log.id,
    message: event.args.message,
    value: event.args.value.toString(),
  }).catch((error) => {
    console.error('Error creating LogEvent:', error)
    console.error('Store method arguments:', {
      id: event.log.id,
      message: event.args.message,
      value: event.args.value.toString(),
    })
  })
})
