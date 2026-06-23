import { useState, useEffect, useCallback } from 'react'
import TransactionForm from './components/TransactionForm'
import TransactionList from './components/TransactionList'
import SummaryCards from './components/SummaryCards'
import './index.css'

export default function App() {
  const [transactions, setTransactions] = useState([])
  const [summary, setSummary] = useState([])
  const [loading, setLoading] = useState(true)
  const [toast, setToast] = useState(null)

  const fetchData = useCallback(async () => {
    try {
      const [txRes, sumRes] = await Promise.all([
        fetch('/transactions'),
        fetch('/transactions/summary'),
      ])
      setTransactions(await txRes.json())
      setSummary(await sumRes.json())
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { fetchData() }, [fetchData])

  const showToast = (message, type = 'success') => {
    setToast({ message, type })
    setTimeout(() => setToast(null), 3000)
  }

  const handleAdd = async (data) => {
    try {
      const res = await fetch('/transactions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      })
      if (!res.ok) throw new Error()
      showToast('Transaction added')
      fetchData()
    } catch {
      showToast('Failed to add transaction', 'error')
    }
  }

  const handleDelete = async (id) => {
    try {
      const res = await fetch(`/transactions/${id}`, { method: 'DELETE' })
      if (!res.ok) throw new Error()
      showToast('Transaction deleted')
      fetchData()
    } catch {
      showToast('Failed to delete transaction', 'error')
    }
  }

  return (
    <div>
      <header className="header">
        <div className="header-logo">F</div>
        <div className="header-text">
          <h1>FinCorp Tracker</h1>
          <p>Secure spend tracking pipeline</p>
        </div>
      </header>
      <main className="main">
        <TransactionForm onAdd={handleAdd} />
        <div className="panels">
          <TransactionList transactions={transactions} loading={loading} onDelete={handleDelete} />
          <SummaryCards summary={summary} loading={loading} />
        </div>
      </main>
      {toast && (
        <div className={`toast toast-${toast.type}`}>{toast.message}</div>
      )}
    </div>
  )
}
