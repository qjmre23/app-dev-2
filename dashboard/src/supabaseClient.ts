import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export interface Order {
  id: string
  user_id: string
  toy_id: string
  toy_name: string
  category: string
  rfid_uid: string
  assigned_person: string
  status: 'PENDING' | 'PROCESSING' | 'ON_THE_WAY' | 'DELIVERED'
  total_amount: number
  created_at: string
  updated_at: string
}

export interface Toy {
  id: string
  name: string
  category: string
  rfid_uid: string
  price: number
  image_url: string | null
  stock: number
  created_at: string
}

export interface Employee {
  id: string
  name: string
  category: string
  rfid_uid: string
  active: boolean
}
