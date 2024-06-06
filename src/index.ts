import { ponder } from '@/generated'

ponder.on('BaluniV1Router:Mint', async ({ event, context }) => {
  const { MintEvent } = context.db

  console.log('Processing Mint event:', (event as any).args)

  // Additional debug logs
  console.log('Mint event log ID:', (event as any).log.id)
  console.log('Mint event user:', (event as any).args.user)
  console.log('Mint event value:', (event as any).args.value.toString())

  try {
    await MintEvent.create({
      id: (event as any).log.id,
      data: {
        user: (event as any).args.user,
        value: (event as any).args.value,
      },
    })
    console.log('MintEvent created successfully')
  } catch (error) {
    console.error('Error creating MintEvent:', error)
    console.error('Store method arguments:', {
      id: (event as any).log.id,
      user: (event as any).args.user,
      value: (event as any).args.value.toString(),
    })
  }
})

// Similarly, update other event handlers if necessary
ponder.on('BaluniV1Router:Execute', async ({ event, context }) => {
  const { ExecuteEvent, Call } = context.db

  console.log('Processing Execute event:', (event as any).args)

  const callData = (event as any).args.calls.map((call: any, index: number) => ({
    id: `${(event as any)?.log?.id}-call-${index}`, // Update the code to include optional chaining and type assertion
    to: call.to,
    value: call.value.toString(),
    data: call.data,
  }))

  await Promise.all(
    callData.map(async (call: { id: string; data: { to: `0x${string}`; value: bigint; data: string } }) => {
      await Call.create(call)
    })
  )

  await ExecuteEvent.create({
    id: (event as any).log.id,
    data: {
      user: (event as any).args.user,
      calls: callData.map((call: { id: any }) => call.id),
      tokensReturn: (event as any).args.tokensReturn,
    },
  }).catch((error) => {
    console.error('Error creating ExecuteEvent:', error)
    console.error('Store method arguments:', {
      id: (event as any).log.id, // Update the code to include type assertion
      user: (event as any).args.user,
      calls: callData.map((call: { id: any }) => call.id),
      tokensReturn: (event as any).args.tokensReturn,
    })
  })
})

ponder.on('BaluniV1Router:Burn', async ({ event, context }) => {
  const { BurnEvent } = context.db

  console.log('Processing Log event:', (event as any).args)

  await BurnEvent.create({
    id: (event as any).log.id,
    data: {
      user: (event as any).args.user,
      value: (event as any).args.value,
    },
  }).catch((error) => {
    console.error('Error creating BurnEvent:', error)
    console.error('Store method arguments:', {
      id: (event as any).log.id,
      user: (event as any).args.user,
      value: (event as any).args.value.toString(),
    })
  })
})

ponder.on('BaluniV1Router:Log', async ({ event, context }) => {
  const { LogEvent } = context.db

  console.log('Processing Log event:', (event as any).args)

  await LogEvent.create({
    id: (event as any).log.id,
    data: {
      message: (event as any).args.message,
      value: (event as any).args.value.toString(),
    },
  }).catch((error) => {
    console.error('Error creating LogEvent:', error)
    console.error('Store method arguments:', {
      id: (event as any).log.id,
      message: (event as any).args.message,
      value: (event as any).args.value.toString(),
    })
  })
})
