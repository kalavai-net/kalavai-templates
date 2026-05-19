# Service monitoring

## OneUptime

https://oneuptime.com/docs/en

Local install:

git clone --depth 1 --single-branch --branch release https://github.com/OneUptime/oneuptime.git
cd oneuptime
cp config.example.env config.env
# configure config.env
npm start

Stop:

npm run down
Kubernetes: https://artifacthub.io/packages/helm/oneuptime/oneuptime

