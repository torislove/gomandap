import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.0'
import Stripe from 'https://esm.sh/stripe@14.5.0?target=deno'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') as string, {
  apiVersion: '2023-10-16',
  httpClient: Stripe.createFetchHttpClient(),
})

const endpointSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET') as string

serve(async (req) => {
  const signature = req.headers.get('stripe-signature')
  if (!signature) return new Response('No signature', { status: 400 })

  const body = await req.text()
  let event

  try {
    event = stripe.webhooks.constructEvent(body, signature, endpointSecret)
  } catch (err: any) {
    return new Response(`Webhook Error: ${err.message}`, { status: 400 })
  }

  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '' // Service role to bypass RLS for webhook
  )

  switch (event.type) {
    case 'checkout.session.completed':
      const session = event.data.object
      const bookingId = session.metadata.bookingId
      
      // Escrow funded successfully!
      await supabaseClient
        .from('bookings')
        .update({ escrow_status: 'Funded', payment_intent_id: session.payment_intent })
        .eq('id', bookingId)
      break
    
    case 'payment_intent.canceled':
      const pi = event.data.object
      // Escrow rejected or failed
      await supabaseClient
        .from('bookings')
        .update({ escrow_status: 'Refunded' })
        .eq('payment_intent_id', pi.id)
      break

    default:
      console.log(`Unhandled event type ${event.type}`)
  }

  return new Response(JSON.stringify({ received: true }), { status: 200 })
})
