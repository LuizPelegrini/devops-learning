# install pnpm in the base image
FROM node:20 AS base_image
RUN npm i -g pnpm

# create another image from base image for installation step
FROM base_image AS dependencies
WORKDIR /usr/src/app
COPY ./package.json ./pnpm-lock.yaml ./
RUN pnpm install

# create another image from base image for build step
FROM base_image AS build
WORKDIR /usr/src/app
COPY . .
# copy node_modules folder generated on last image
COPY --from=dependencies /usr/src/app/node_modules ./node_modules
RUN pnpm build
RUN pnpm prune --prod

# create another node20 alpine distro for deploy step
FROM node:20-alpine3.19 AS deploy
WORKDIR /usr/src/app
RUN npm i -g pnpm prisma
# copy generated files from last image (build) 
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/prisma ./prisma
COPY --from=build /usr/src/app/node_modules ./node_modules
RUN pnpm prisma generate
# the port the application is running at
EXPOSE 3333
# all the steps above will create the image using `docker build -t <image_name>:<tag> <dockerfile_location>`
# eg. `docker build -t passin:v1 .`

# when we run `docker run -p 3001:3333 -d passin:v1` then the command below will be executed, creating the container from the image passin:v1
# `-d` to start the container in detached mode so the terminal can continue to be used
CMD [ "pnpm", "start" ]