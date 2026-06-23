const fmt = (n) =>
  new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(n)

export default function SummaryCards({ summary, loading }) {
  const max = summary.length
    ? Math.max(...summary.map((s) => parseFloat(s.total)))
    : 1

  const total = summary.reduce((acc, s) => acc + parseFloat(s.total), 0)

  return (
    <div className="card">
      <p className="card-title">Spending by Category</p>

      {loading ? (
        <div>
          {[...Array(3)].map((_, i) => (
            <div key={i} className="skeleton" style={{ marginBottom: 22, height: 36 }} />
          ))}
        </div>
      ) : summary.length === 0 ? (
        <div className="empty">No data yet.</div>
      ) : (
        <>
          <div className="summary-list">
            {summary.map((item) => (
              <div key={item.category}>
                <div className="summary-item-header">
                  <span>{item.category}</span>
                  <span>{fmt(item.total)}</span>
                </div>
                <div className="bar-track">
                  <div
                    className="bar-fill"
                    style={{ width: `${(parseFloat(item.total) / max) * 100}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
          <div style={{
            marginTop: 20,
            paddingTop: 16,
            borderTop: '1px solid var(--border)',
            display: 'flex',
            justifyContent: 'space-between',
            fontSize: '0.875rem',
          }}>
            <span style={{ color: 'var(--text-muted)', fontWeight: 500 }}>Total</span>
            <span style={{ fontWeight: 700, color: 'var(--text)' }}>{fmt(total)}</span>
          </div>
        </>
      )}
    </div>
  )
}
