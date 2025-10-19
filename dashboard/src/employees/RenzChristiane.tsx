import { useEffect, useState, useRef } from 'react'
import { supabase, Order } from '../supabaseClient'

export default function RenzChristiane() {
  const [orders, setOrders] = useState<Order[]>([])
  const [connected, setConnected] = useState(false)
  const audioRef = useRef<HTMLAudioElement | null>(null)
  const [audioEnabled, setAudioEnabled] = useState(false)

  useEffect(() => {
    audioRef.current = new Audio('/sounds/renz.mp3')
  }, [])

  const enableAudio = async () => {
    try {
      if (audioRef.current) {
        audioRef.current.muted = true
        await audioRef.current.play()
        audioRef.current.pause()
        audioRef.current.currentTime = 0
        audioRef.current.muted = false
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
      .channel('renz-christiane-orders')
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'orders', filter: `category=eq.Puzzles` },
        (payload) => {
          const newOrder = payload.new as Order
          setOrders((prev) => [newOrder, ...prev])
          if (audioEnabled && audioRef.current) {
            audioRef.current.play().catch(console.error)
          }
        }
      )
      .on(
        'postgres_changes',
        { event: 'UPDATE', schema: 'public', table: 'orders', filter: `category=eq.Puzzles` },
        (payload) => {
          const updatedOrder = payload.new as Order
          setOrders((prev) => prev.map((o) => (o.id === updatedOrder.id ? updatedOrder : o)))
        }
      )
      .on(
        'postgres_changes',
        { event: 'DELETE', schema: 'public', table: 'orders', filter: `category=eq.Puzzles` },
        (payload) => {
          const deletedId = payload.old.id
          setOrders((prev) => prev.filter((o) => o.id !== deletedId))
        }
      )
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
      .eq('category', 'Puzzles')
      .order('created_at', { ascending: false })
    if (error) {
      console.error('Error fetching orders:', error)
    } else {
      setOrders(data || [])
    }
  }

  const stats = {
    total: orders.length,
    pending: orders.filter((o) => o.status === 'PENDING').length,
    inProgress: orders.filter((o) => ['PROCESSING', 'ON_THE_WAY'].includes(o.status)).length,
    delivered: orders.filter((o) => o.status === 'DELIVERED').length,
  }

  if (!audioEnabled) {
    return (
      <div style={styles.modal}>
        <div style={styles.modalContent}>
          <h2>Renz Christiane Ming - Puzzles</h2>
          <p>Click to enable audio notifications for your orders</p>
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
        <h1 style={styles.title}>🧩 Renz Christiane Ming - Puzzles</h1>
        <div style={{ ...styles.connectionStatus, ...(connected ? styles.connected : styles.disconnected) }}>
          <div style={styles.statusIndicator}></div>
          <span>{connected ? 'Connected' : 'Disconnected'}</span>
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
      </div>

      <div style={styles.content}>
        <h2 style={styles.contentTitle}>My Orders</h2>
        <div style={styles.tableContainer}>
          <table style={styles.table}>
            <thead>
              <tr>
                <th style={styles.th}>Toy Name</th>
                <th style={styles.th}>RFID UID</th>
                <th style={styles.th}>Status</th>
                <th style={styles.th}>Amount</th>
                <th style={styles.th}>Created</th>
              </tr>
            </thead>
            <tbody>
              {orders.length === 0 ? (
                <tr>
                  <td colSpan={5} style={styles.emptyState}>
                    No orders yet
                  </td>
                </tr>
              ) : (
                orders.map((order) => (
                  <tr key={order.id} style={styles.tr}>
                    <td style={styles.td}>{order.toy_name}</td>
                    <td style={styles.td}>{order.rfid_uid}</td>
                    <td style={styles.td}>
                      <span style={{ ...styles.badge, ...styles[`badge${order.status}`] }}>{order.status}</span>
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
    background: 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)',
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
    backgroundColor: '#f59e0b',
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
