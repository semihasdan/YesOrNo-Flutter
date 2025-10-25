# Firebase Deployment Script
# Deploys Cloud Functions, Firestore rules, and indexes to production

echo "🚀 Starting Firebase Deployment..."

# Set project
echo "📋 Setting Firebase project..."
firebase use production

# Deploy Firestore security rules
echo "🔒 Deploying Firestore security rules..."
firebase deploy --only firestore:rules

# Deploy Firestore indexes
echo "📊 Deploying Firestore indexes..."
firebase deploy --only firestore:indexes

# Install Cloud Functions dependencies
echo "📦 Installing Cloud Functions dependencies..."
cd functions
npm install
cd ..

# Deploy Cloud Functions
echo "☁️  Deploying Cloud Functions..."
firebase deploy --only functions

# Configure Cloud Scheduler (if not already configured)
echo "⏰ Checking Cloud Scheduler configuration..."
gcloud scheduler jobs describe handleTimeout-scheduler \
  --location=europe-west1 \
  --project=$(firebase use --print) || \
gcloud scheduler jobs create http handleTimeout-scheduler \
  --schedule="*/30 * * * *" \
  --uri="https://europe-west1-$(firebase use --print).cloudfunctions.net/handleTimeout" \
  --http-method=POST \
  --location=europe-west1 \
  --project=$(firebase use --print)

echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "1. Test the deployment with integration tests"
echo "2. Monitor Cloud Functions logs: firebase functions:log"
echo "3. Check Firestore security rules in Firebase Console"
echo "4. Verify Cloud Scheduler job is running"
