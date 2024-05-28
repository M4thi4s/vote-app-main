FROM --platform=linux/amd64 node:18-slim AS BUILD

# Set the working directory in the container
WORKDIR /usr/local/app

# Copy package.json and package-lock.json
COPY package*.json ./

RUN npm install -g nodemon

# Install project dependencies
RUN npm ci
RUN npm cache clean --force
RUN mv /usr/local/app/node_modules /node_modules

# Copy the rest of the application code
COPY . .

# Set the PORT environment variable
ENV PORT 4000

CMD [ "node", "server.js" ]