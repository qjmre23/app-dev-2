import { useEffect, useState, useRef } from 'react'
import { supabase, Order } from './supabaseClient'

export default function Admin() {
  const [orders, setOrders] = useState<Order[]>([])
  const [connected, setConnected] = useState(false)
  const audioRefs = useRef<{ [key: string]: HTMLAudioElement }>({})
  const [audioEnabled, setAudioEnabled] = useState(false)

  useEffect(() => {
    audioRefs.current = {
      'Toy Guns': new Audio('/sounds/ebona.mp3'),
      'Action Figures': new Audio('/sounds/cruz.mp3'),
      'Dolls': new Audio('/sounds/marl.mp3'),
      'Puzzles': new Audio('/sounds/renz.mp3'),
    }
  }, [])

  const enableAudio = async () => {
    try {
      for (const audio of Object.values(audioRefs.current)) {
        audio.muted = true
        await audio.play()
        audio.pause()
        audio.currentTime = 0
        audio.muted = false
      }
      setAudioEnabled(true)
    } catch (error) {
      console.error('Audio enable failed:', error)
      setAudioEnabled(true)
    }
  }

  useEffect(() => {
    fetchOrders()

    const channel = supabase
      .channel('orders-channel')
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'orders' }, (payload) => {
        const newOrder = payload.new as Order
        setOrders((prev) => [newOrder, ...prev])
        if (audioEnabled && audioRefs.current[newOrder.category]) {
          audioRefs.current[newOrder.category].play().catch(console.error)
        }
      })
      .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'orders' }, (payload) => {
        const updatedOrder = payload.new as Order
        setOrders((prev) => prev.map((o) => (o.id === updatedOrder.id ? updatedOrder : o)))
      })
      .on('postgres_changes', { event: 'DELETE', schema: 'public', table: 'orders' }, (payload) => {
        const deletedId = payload.old.id
        setOrders((prev) => prev.filter((o) => o.id !== deletedId))
      })
      .subscribe((status) => {
        setConnected(status === 'SUBSCRIBED')
      })

    return () => {
      supabase.removeChannel(channel)
    }
  }, [audioEnabled])

  const fetchOrders = async () => {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .order('created_at', { ascending: false })
    if (error) {
      console.error('Error fetching orders:', error)
    } else {
      setOrders(data || [])
    }
  }

  const clearAllOrders = async () => {
    if (!confirm('Are you sure you want to delete all orders? This action cannot be undone.')) return
    const { error } = await supabase.from('orders').delete().neq('id', '00000000-0000-0000-0000-000000000000')
    if (error) {
      console.error('Error clearing orders:', error)
      alert('Failed to clear orders')
    } else {
      setOrders([])
    }
  }

  const stats = {
    total: orders.length,
    pending: orders.filter((o) => o.status === 'PENDING').length,
    inProgress: orders.filter((o) => ['PROCESSING', 'ON_THE_WAY'].includes(o.status)).length,
    delivered: orders.filter((o) => o.status === 'DELIVERED').length,
    revenue: orders.reduce((sum, o) => sum + o.total_amount, 0),
  }

  if (!audioEnabled) {
    return (
      <div style={styles.modal}>
        <div style={styles.modalContent}>
          <h2>Welcome to Admin Dashboard</h2>
          <p>Click to enable audio notifications for new orders</p>
          <button onClick={enableAudio} style={styles.enableButton}>
            Enable Sound & Enter
          </button>
        </div>
      </div>
    )
  }

  return (
    <div style={styles.container}>
      <div style={styles.header}>
        <h1 style={styles.title}>🧸 Smart Toy Store - Admin Dashboard</h1>
        <div style={styles.headerControls}>
          <div style={{ ...styles.connectionStatus, ...(connected ? styles.connected : styles.disconnected) }}>
            <div style={styles.statusIndicator}></div>
            <span>{connected ? 'Connected' : 'Disconnected'}</span>
          </div>
          <button onClick={clearAllOrders} style={styles.clearButton}>
            Clear History
          </button>
        </div>
      </div>

      <div style={styles.stats}>
        <div style={styles.statCard}>
          <h3 style={styles.statLabel}>Total Orders</h3>
          <div style={styles.statValue}>{stats.total}</div>
        </div>
        <div style={styles.statCard}>
          <h3 style={styles.statLabel}>Pending</h3>
          <div style={{ ...styles.statValue, color: '#f59e0b' }}>{stats.pending}</div>
        </div>
        <div style={styles.statCard}>
          <h3 style={styles.statLabel}>In Progress</h3>
          <div style={{ ...styles.statValue, color: '#3b82f6' }}>{stats.inProgress}</div>
        </div>
        <div style={styles.statCard}>
          <h3 style={styles.statLabel}>Delivered</h3>
          <div style={{ ...styles.statValue, color: '#10b981' }}>{stats.delivered}</div>
        </div>
        <div style={styles.statCard}>
          <h3 style={styles.statLabel}>Total Revenue</h3>
          <div style={{ ...styles.statValue, color: '#8b5cf6' }}>${stats.revenue.toFixed(2)}</div>
        </div>
      </div>

      <div style={styles.content}>
        <h2 style={styles.contentTitle}>Live Orders</h2>
        <div style={styles.tableContainer}>
          <table style={styles.table}>
            <thead>
              <tr>
                <th style={styles.th}>Category</th>
                <th style={styles.th}>Toy Name</th>
                <th style={styles.th}>RFID UID</th>
                <th style={styles.th}>Assigned Person</th>
                <th style={styles.th}>Status</th>
                <th style={styles.th}>Amount</th>
                <th style={styles.th}>Created</th>
              </tr>
            </thead>
            <tbody>
              {orders.length === 0 ? (
                <tr>
                  <td colSpan={7} style={styles.emptyState}>
                    No orders yet
                  </td>
                </tr>
              ) : (
                orders.map((order) => (
                  <tr key={order.id} style={styles.tr}>
                    <td style={styles.td}>{order.category}</td>
                    <td style={styles.td}>{order.toy_name}</td>
                    <td style={styles.td}>{order.rfid_uid}</td>
                    <td style={styles.td}>{order.assigned_person}</td>
                    <td style={styles.td}>
                      <span style={{ ...styles.badge, ...styles[`badge${order.status}`] }}>
                        {order.status}
                      </span>
                    </td>
                    <td style={styles.td}>${order.total_amount.toFixed(2)}</td>
                    <td style={styles.td}>{new Date(order.created_at).toLocaleString()}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

const styles: { [key: string]: React.CSSProperties } = {
  container: {
    minHeight: '100vh',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    padding: '20px',
  },
  modal: {
    position: 'fixed',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
    background: 'rgba(0, 0, 0, 0.7)',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 1000,
  },
  modalContent: {
    background: 'white',
    padding: '40px',
    borderRadius: '12px',
    textAlign: 'center',
    boxShadow: '0 5px 15px rgba(0,0,0,0.3)',
  },
  enableButton: {
    padding: '12px 25px',
    fontSize: '16px',
    cursor: 'pointer',
    border: 'none',
    borderRadius: '8px',
    backgroundColor: '#667eea',
    color: 'white',
    fontWeight: 'bold',
    marginTop: '20px',
  },
  header: {
    background: 'white',
    padding: '24px',
    borderRadius: '12px',
    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
    marginBottom: '24px',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    flexWrap: 'wrap',
  },
  title: {
    fontSize: '28px',
    color: '#333',
    margin: 0,
  },
  headerControls: {
    display: 'flex',
    gap: '10px',
    alignItems: 'center',
  },
  connectionStatus: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    padding: '8px 16px',
    borderRadius: '20px',
    fontSize: '14px',
    fontWeight: '600',
  },
  connected: {
    background: '#10b981',
    color: 'white',
  },
  disconnected: {
    background: '#ef4444',
    color: 'white',
  },
  statusIndicator: {
    width: '10px',
    height: '10px',
    borderRadius: '50%',
    background: 'white',
  },
  clearButton: {
    padding: '8px 16px',
    fontSize: '14px',
    cursor: 'pointer',
    border: '1px solid #ef4444',
    borderRadius: '8px',
    backgroundColor: '#fee2e2',
    color: '#991b1b',
    fontWeight: 'bold',
  },
  stats: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
    gap: '16px',
    marginBottom: '24px',
  },
  statCard: {
    background: 'white',
    padding: '20px',
    borderRadius: '12px',
    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
  },
  statLabel: {
    fontSize: '14px',
    color: '#666',
    margin: 0,
    marginBottom: '8px',
  },
  statValue: {
    fontSize: '32px',
    fontWeight: 'bold',
    color: '#333',
    margin: 0,
  },
  content: {
    background: 'white',
    padding: '24px',
    borderRadius: '12px',
    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
  },
  contentTitle: {
    fontSize: '20px',
    color: '#333',
    marginTop: 0,
    marginBottom: '20px',
  },
  tableContainer: {
    overflowX: 'auto',
  },
  table: {
    width: '100%',
    borderCollapse: 'collapse',
  },
  th: {
    padding: '12px',
    textAlign: 'left',
    background: '#f8f9fa',
    fontWeight: '600',
    color: '#555',
    borderBottom: '2px solid #e9ecef',
  },
  td: {
    padding: '12px',
    borderBottom: '1px solid #e9ecef',
  },
  tr: {
    transition: 'background 0.2s',
  },
  badge: {
    display: 'inline-block',
    padding: '4px 12px',
    borderRadius: '20px',
    fontSize: '12px',
    fontWeight: '600',
    textTransform: 'uppercase',
  },
  badgePENDING: {
    background: '#fef3c7',
    color: '#92400e',
  },
  badgePROCESSING: {
    background: '#dbeafe',
    color: '#1e40af',
  },
  badgeON_THE_WAY: {
    background: '#e9d5ff',
    color: '#6b21a8',
  },
  badgeDELIVERED: {
    background: '#d1fae5',
    color: '#065f46',
  },
  emptyState: {
    textAlign: 'center',
    padding: '60px 20px',
    color: '#999',
  },
}
