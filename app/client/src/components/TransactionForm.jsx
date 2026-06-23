import { useState } from 'react'

const CATEGORIES = ['food', 'transport', 'utilities', 'entertainment', 'health', 'other']

export default function TransactionForm({ onAdd }) {
  const [description, setDescription] = useState('')
  const [category, setCategory] = useState('food')
  const [amount, setAmount] = useState('')
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!description.trim() || !amount || Number(amount) <= 0) return
    setSubmitting(true)
    await onAdd({ description: description.trim(), category, amount: Number.parseFloat(amount) })
    setDescription('')
    setAmount('')
    setSubmitting(false)
  }

  return (
    <div className="card">
      <p className="card-title">Log Transaction</p>
      <form onSubmit={handleSubmit}>
        <div className="form-row">
          <div className="form-group form-group--wide">
            <label htmlFor="description">What are you adding?</label>
            <input
              id="description"
              type="text"
              placeholder="e.g. Lunch at KFC"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label htmlFor="category">Category</label>
            <select
              id="category"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
            >
              {CATEGORIES.map((c) => (
                <option key={c} value={c}>
                  {c.charAt(0).toUpperCase() + c.slice(1)}
                </option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label htmlFor="amount">Amount (USD)</label>
            <input
              id="amount"
              type="number"
              min="0.01"
              step="0.01"
              placeholder="0.00"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              required
            />
          </div>
          <button type="submit" className="btn btn-primary" disabled={submitting}>
            {submitting ? 'Adding…' : '+ Add'}
          </button>
        </div>
      </form>
    </div>
  )
}
