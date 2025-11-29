# Use Node 20
FROM node:20

WORKDIR /app

COPY package*.json ./

# Remove optional dependency issues
RUN npm install --legacy-peer-deps

COPY . .

# Expose Vite port
EXPOSE 5173

# Start frontend
CMD ["npm", "run", "dev", "--", "--host"]
