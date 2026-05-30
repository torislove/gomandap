import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.0'
import Stripe from 'https://esm.sh/stripe@14.5.0?target=deno'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') as string, {
  apiVersion: '2023-10-16',
  httpClient: Stripe.createFetchHttpClient(),
})

serve(async (req) => {
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { data: { user } } = await supabaseClient.auth.getUser()
    if (!user) throw new Error('Unauthorized')

    const { amount, currency, bookingId, vendorId } = await req.json()

    // Create Escrow Stripe Session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: currency || 'inr',
            product_data: {
              name: 'GoMandap Escrow Booking',
              description: `Booking ID: ${bookingId}`,
            },
            unit_amount: amount * 100, // Stripe expects minimum unit (e.g., paise)
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: `https://gomandap.com/payment-success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `https://gomandap.com/payment-cancel`,
      metadata: {
        bookingId: bookingId,
        clientId: user.id,
        vendorId: vendorId,
      },
      payment_intent_data: {
        capture_method: 'manual', // Hold funds in Escrow, do not capture immediately
      }
    })

    return new Response(JSON.stringify({ sessionId: session.id, url: session.url }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
