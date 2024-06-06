import { createSchema } from '@ponder/core'

export default createSchema((p) => ({
  Call: p.createTable({
    id: p.string(),
    to: p.hex(),
    value: p.bigint(),
    data: p.string(),
  }),
  Token: p.createTable({
    id: p.string(),
    address: p.hex(),
  }),
  ExecuteEvent: p.createTable({
    id: p.string(),
    user: p.hex(),
    calls: p.hex().list(),
    tokensReturn: p.hex().list(),
  }),
  BurnEvent: p.createTable({
    id: p.string(),
    user: p.hex(),
    value: p.bigint(),
  }),
  MintEvent: p.createTable({
    id: p.string(),
    user: p.hex().optional(),
    value: p.bigint(),
  }),
  LogEvent: p.createTable({
    id: p.string(),
    message: p.string(),
    value: p.bigint(),
  }),
}))
