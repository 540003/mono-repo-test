import express from 'express'
import cors from 'cors'
import path from 'path'
import { fileURLToPath } from 'url'
import dotenv from 'dotenv'

dotenv.config()
import { greet } from '@acme/shared'
console.log(greet('backend'))
const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const PORT =  3000

app.use(cors())
app.use(express.json())

// Example API
app.get('/hello', (req, res) => {
  res.json({ message: 'Hello from backend 🚀' })
})

// ---- Production static serving (after build) ----
// Uncomment when deploying a single server serving the SPA
const distDir = path.resolve(__dirname, '../../apps/frontend/dist')
app.use(express.static(distDir))
app.get('*', (_req, res) => {
  res.sendFile(path.join(distDir, 'index.html'))
})

app.listen(PORT, () => {
  console.log(`Backend running at http://localhost:${PORT}`)
})
