import { BrowserRouter, Routes, Route, Link } from 'react-router-dom'
import Admin from './Admin'
import JohnMarwin from './employees/JohnMarwin'
import JannalynCruz from './employees/JannalynCruz'
import MarlPrince from './employees/MarlPrince'
import RenzChristiane from './employees/RenzChristiane'

function Home() {
  return (
    <div style={styles.container}>
      <div style={styles.content}>
        <h1 style={styles.title}>🧸 Smart Toy Store System</h1>
        <p style={styles.subtitle}>Select Your Dashboard</p>
        <div style={styles.grid}>
          <Link to="/admin" style={{ ...styles.card, background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }}>
            <div style={styles.cardTitle}>Admin Dashboard</div>
            <div style={styles.cardDescription}>View all orders and system overview</div>
          </Link>
          <Link to="/employee/john-marwin" style={{ ...styles.card, background: 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)' }}>
            <div style={styles.cardTitle}>🔫 John Marwin Ebona</div>
            <div style={styles.cardDescription}>Toy Guns Department</div>
          </Link>
          <Link to="/employee/jannalyn-cruz" style={{ ...styles.card, background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)' }}>
            <div style={styles.cardTitle}>🦸 Jannalyn Cruz</div>
            <div style={styles.cardDescription}>Action Figures Department</div>
          </Link>
          <Link to="/employee/marl-prince" style={{ ...styles.card, background: 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)' }}>
            <div style={styles.cardTitle}>👗 Prince Marl Mirasol</div>
            <div style={styles.cardDescription}>Dolls Department</div>
          </Link>
          <Link to="/employee/renz-christiane" style={{ ...styles.card, background: 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)' }}>
            <div style={styles.cardTitle}>🧩 Renz Christiane Ming</div>
            <div style={styles.cardDescription}>Puzzles Department</div>
          </Link>
        </div>
      </div>
    </div>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/admin" element={<Admin />} />
        <Route path="/employee/john-marwin" element={<JohnMarwin />} />
        <Route path="/employee/jannalyn-cruz" element={<JannalynCruz />} />
        <Route path="/employee/marl-prince" element={<MarlPrince />} />
        <Route path="/employee/renz-christiane" element={<RenzChristiane />} />
      </Routes>
    </BrowserRouter>
  )
}

const styles: { [key: string]: React.CSSProperties } = {
  container: {
    minHeight: '100vh',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '20px',
  },
  content: {
    maxWidth: '1200px',
    width: '100%',
  },
  title: {
    fontSize: '48px',
    fontWeight: 'bold',
    color: 'white',
    textAlign: 'center',
    marginBottom: '10px',
  },
  subtitle: {
    fontSize: '24px',
    color: 'white',
    textAlign: 'center',
    marginBottom: '40px',
    opacity: 0.9,
  },
  grid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
    gap: '24px',
  },
  card: {
    padding: '32px',
    borderRadius: '16px',
    boxShadow: '0 10px 30px rgba(0, 0, 0, 0.3)',
    textDecoration: 'none',
    transition: 'transform 0.3s, box-shadow 0.3s',
    cursor: 'pointer',
  },
  cardTitle: {
    fontSize: '24px',
    fontWeight: 'bold',
    color: 'white',
    marginBottom: '12px',
  },
  cardDescription: {
    fontSize: '16px',
    color: 'white',
    opacity: 0.9,
  },
}
