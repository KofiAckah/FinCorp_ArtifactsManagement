import PropTypes from 'prop-types'

const fmt = (n) =>
  new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(n)

const fmtDate = (d) =>
  new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })

function TrashIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
      strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="3 6 5 6 21 6" />
      <path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6" />
      <path d="M10 11v6M14 11v6" />
      <path d="M9 6V4a1 1 0 011-1h4a1 1 0 011 1v2" />
    </svg>
  )
}

export default function TransactionList({ transactions, loading, onDelete }) {
  return (
    <div className="card">
      <p className="card-title">Recent Transactions</p>

      {loading ? (
        <div>
          {[...Array(5)].map((_, i) => (
            <div key={i} className="skeleton" style={{ width: `${70 + (i % 3) * 10}%` }} />
          ))}
        </div>
      ) : transactions.length === 0 ? (
        <div className="empty">No transactions yet. Log your first spend above.</div>
      ) : (
        <div style={{ overflowX: 'auto' }}>
          <table className="tx-table">
            <thead>
              <tr>
                <th>Description</th>
                <th>Category</th>
                <th>Amount</th>
                <th>Date</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {transactions.map((tx) => (
                <tr key={tx.id}>
                  <td style={{ fontWeight: 500 }}>{tx.description}</td>
                  <td><span className="badge">{tx.category}</span></td>
                  <td><span className="amount">{fmt(tx.amount)}</span></td>
                  <td style={{ color: 'var(--text-muted)', fontSize: '0.82rem' }}>
                    {fmtDate(tx.created_at)}
                  </td>
                  <td>
                    <button
                      className="btn-delete"
                      onClick={() => onDelete(tx.id)}
                      title="Delete transaction"
                    >
                      <TrashIcon />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}

TransactionList.propTypes = {
  transactions: PropTypes.arrayOf(PropTypes.shape({
    id:          PropTypes.number.isRequired,
    description: PropTypes.string.isRequired,
    category:    PropTypes.string.isRequired,
    amount:      PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
    created_at:  PropTypes.string.isRequired,
  })).isRequired,
  loading:  PropTypes.bool.isRequired,
  onDelete: PropTypes.func.isRequired,
}
